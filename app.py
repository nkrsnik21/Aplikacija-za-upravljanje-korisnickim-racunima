from flask import Flask, render_template, request, redirect, url_for, session
import psycopg2
import json
import os
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Zamijenite s vlastitim tajnim ključem

# Funkcija za povezninaje s bazom podataka
def get_db_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="korisnicki_racuni",  # Promijenite prema imenu vaše baze
        user="nina",  # Zamijenite s vašim korisničkim imenom
        password="nina"  # Zamijenite s vašom lozinkom
    )
    return conn


@app.route('/')
def index():
    return redirect(url_for('login'))  # Redirekt na login stranicu


# Route za prijavu
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM korisnici WHERE username = %s AND password = %s", (username, password))
        user = cur.fetchone()
        cur.close()

        if user:
            session['user_id'] = user[0]
            session['username'] = user[1]
            session['role'] = user[4]

            # Ako je korisnik superadmin, povuci sve metapodatke
            if user[4] == 'super_admin':
                cur = conn.cursor()
                cur.execute("""
                    SELECT korisnici.username, meta_podaci.atribut, meta_podaci.vrijednost, meta_podaci.azurirano 
                    FROM meta_podaci
                    JOIN korisnici ON meta_podaci.korisnik_id = korisnici.id
                """)
                metapodaci = load_meta_data()
                metapodaci = cur.fetchall()
                session['metapodaci'] = metapodaci  # Spremi metapodatke u sesiju
                cur.close()

            # Ažuriranje metapodataka za korisnika
            update_meta_data(user[0], 'posljednja_prijava', str(datetime.now()))  # Trenutni datum i vrijeme
            # Povećavanje broja prijava
            cur = conn.cursor()
            cur.execute("""
                UPDATE meta_podaci
                SET vrijednost = CAST(vrijednost AS INTEGER) + 1
                WHERE korisnik_id = %s AND atribut = 'broj_prijava'
            """, (user[0],))
            if cur.rowcount == 0:  # Ako nema zapisa, dodaj novi
                cur.execute("""
                    INSERT INTO meta_podaci (korisnik_id, atribut, vrijednost)
                    VALUES (%s, 'broj_prijava', '1')
                """, (user[0],))
            conn.commit()
            cur.close()
            conn.close()

            return redirect(url_for('dashboard'))
        else:
            error = 'Neispravno korisničko ime ili lozinka'
            return render_template('login.html', error=error)
    return render_template('login.html')

def load_meta_data():
    if os.path.exists('meta_podaci.json'):
        with open('meta_podaci.json', 'r') as file:
            return json.load(file)
    return []  # Ako datoteka ne postoji, vraća prazan popis

# Funkcija za pohranu metapodataka u JSON datoteku
def save_meta_data(meta_data):
    with open('meta_podaci.json', 'w') as file:
        json.dump(meta_data, file, indent=4)


# Funkcija za ažuriranje metapodataka
def update_meta_data(korisnik_id, atribut, vrijednost):
    meta_data = load_meta_data()

    # Provjera postoji li već metapodatak za tog korisnika i atribut
    found = False
    for meta in meta_data:
        if meta['korisnik_id'] == korisnik_id and meta['atribut'] == atribut:
            meta['vrijednost'] = vrijednost
            meta['azurirano'] = str(datetime.now())  # Ažuriraj datum
            found = True
            break

    # Ako metapodatak ne postoji, dodaj novi
    if not found:
        meta_data.append({
            'korisnik_id': korisnik_id,
            'atribut': atribut,
            'vrijednost': vrijednost,
            'azurirano': str(datetime.now())
        })

    # Spremi ažurirane metapodatke natrag u JSON datoteku
    save_meta_data(meta_data)



# Route za dashboard
@app.route('/dashboard')
def dashboard():
    if 'username' not in session:
        return redirect(url_for('login'))

    role = session['role']
    
    conn = get_db_connection()
    cur = conn.cursor()

    # Dohvaćanje svih postova iz tablice postovi
    cur.execute("SELECT * FROM postovi")
    postovi = cur.fetchall()

    # Dohvaćanje svih postova iz tablice postovi_status
    cur.execute("SELECT * FROM postovi_status")
    postovi_status = cur.fetchall()

    # Pravimo skup ID-ova postova koji su već u postovi_status
    postovi_status_ids = {post[0] for post in postovi_status}

    # Filtriramo postove iz tablice postovi, tako da ne dodajemo one koji su već u postovi_status
    jedinstveni_postovi = [post for post in postovi if post[0] not in postovi_status_ids]

    # Kombiniramo jedinstvene postove iz postovi s postovima iz postovi_status
    svi_postovi = jedinstveni_postovi + postovi_status

    # Dohvaćanje metapodataka i korisnika (samo za superadmina)
    metapodaci = []
    korisnici = []
    if role == 'super_admin':
        metapodaci = session.get('metapodaci', [])  # Dohvati metapodatke iz sesije
        cur.execute("SELECT * FROM korisnici")
        korisnici = cur.fetchall()

    cur.close()
    conn.close()

    return render_template('dashboard.html', 
                           role=role, 
                           postovi=svi_postovi, 
                           metapodaci=metapodaci, 
                           korisnici=korisnici)


# Route za dodavanje novog postova (samo za moderatora)
@app.route('/dodaj-post', methods=['GET', 'POST'])
def dodaj_post():
    if 'username' not in session:
        return redirect(url_for('login'))

    # Provjera uloge u sesiji
    print(f"Uloga korisnika: {session.get('role')}")

    if session['role'] not in ['moderator', 'super_admin']:
        return redirect(url_for('dashboard'))

    if request.method == 'POST':
        naslov = request.form['naslov']
        sadrzaj = request.form['sadrzaj']

        conn = get_db_connection()
        cur = conn.cursor()

        if session['role'] == 'super_admin':
            # Ako je super_admin, post ide samo u postovi_status
            status = request.form['status']  # Superadmin bira status
            cur.execute("""
                INSERT INTO postovi_status (naslov, sadrzaj, status)
                VALUES (%s, %s, %s)
            """, (naslov, sadrzaj, status))
        else:
            # Ako je moderator, post ide samo u postovi
            cur.execute("""
                INSERT INTO postovi (naslov, sadrzaj, autor_id)
                VALUES (%s, %s, %s)
            """, (naslov, sadrzaj, session['user_id']))

        conn.commit()
        cur.close()
        conn.close()

        return redirect(url_for('dashboard'))

    # Debugging: Provjera role
    print(f"Role poslano u render_template: {session.get('role')}")

    return render_template('dodaj_post.html', role=session.get('role'))


# Route za brisanje postova (samo za admina i superadmina)
@app.route('/obrisi-post/<int:id>', methods=['POST'])
def obrisi_post(id):
    if 'username' not in session:
        return redirect(url_for('login'))

    if session['role'] not in ['admin', 'super_admin']:
        return redirect(url_for('dashboard'))

    conn = get_db_connection()
    cur = conn.cursor()

    # Provjera u kojoj tablici se nalazi post (postovi_status ili postovi)
    cur.execute("SELECT * FROM postovi WHERE id = %s", (id,))
    post = cur.fetchone()

    if post:
        # Ako post postoji u tablici postovi
        cur.execute("DELETE FROM postovi WHERE id = %s", (id,))
    else:
        # Ako post nije pronađen u postovi, provjeri u postovi_status
        cur.execute("SELECT * FROM postovi_status WHERE id = %s", (id,))
        post_status = cur.fetchone()
        
        if post_status:
            # Ako post postoji u postovi_status
            cur.execute("DELETE FROM postovi_status WHERE id = %s", (id,))
    
    conn.commit()
    cur.close()
    conn.close()

    return redirect(url_for('dashboard'))


# Route za logout
@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))


# Route za dodavanje novog korisnika (samo za superadmina)
@app.route('/dodaj-korisnika', methods=['GET', 'POST'])
def dodaj_korisnika():
    if 'username' not in session:
        return redirect(url_for('login'))

    if session['role'] != 'super_admin':
        return redirect(url_for('dashboard'))

    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        role = request.form['role']
        inherits = request.form['inherits']

        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO korisnici (username, password, email, role, inherits)
            VALUES (%s, %s, %s, %s, %s)
        """, (username, password, email, role, inherits))
        conn.commit()
        cur.close()
        conn.close()

        return redirect(url_for('dashboard'))

    return render_template('add_user.html')


# Route za brisanje korisnika (samo za superadmina)
@app.route('/obrisi-korisnika/<int:id>', methods=['POST'])
def obrisi_korisnika(id):
    if 'username' not in session:
        return redirect(url_for('login'))

    if session['role'] != 'super_admin':
        return redirect(url_for('dashboard'))

    conn = get_db_connection()
    cur = conn.cursor()
    
    # Brisanje korisnika iz baze podataka
    cur.execute("DELETE FROM korisnici WHERE id = %s", (id,))
    conn.commit()
    
    cur.close()
    conn.close()

    return redirect(url_for('dashboard'))



@app.route('/meta-podaci')
def meta_podaci():
    if 'username' not in session:
        return redirect(url_for('login'))  # Provjerava je li korisnik prijavljen

    role = session.get('role')  # Dobivanje uloge korisnika iz sesije
    if role != 'super_admin':
        return redirect(url_for('dashboard'))  # Samo super_admin može vidjeti ovu stranicu
        
    # Učitaj meta podatke
    meta_data = load_meta_data()
    # Proslijedi podatke u HTML predložak
    return render_template('meta_podaci.html', meta_data=meta_data)


if __name__ == '__main__':
    app.run(debug=True)
