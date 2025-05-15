# CCH
CarCareHub

### Setup projekta
1. Pokrenite terminal unutar foldera u kojem se nalazi repozitorij
2. U terminalu cd CCH/CarCareHub_
3. docker-compose up --build

### Kredencijali
1. Admin
   **USERNAME:** Admin
   **PASSWORD:** Admin 
2. Autoservis
   **USERNAME:** autoservis
   **PASSWORD:** autoservis
3. Firma autodijelova
   **USERNAME:** firma
   **PASSWORD:** firma
4. Klijent
   **USERNAME:** klijent
   **PASSWORD:** klijent   
5. Zaposlenik
   **USERNAME:** zaposlenik
   **PASSWORD:** zaposlenik

### Stripe Testna kartica
- Broj kartice: 4242 4242 4242 4242
- Datum isteka: bilo koji datum u budućnosti
- CVC: bilo koji trocifreni broj

### Napomene
1. Prilikom pokretanja API-a kroz Swagger u url potrebno dodati "/swagger/index.html"
2. API_HOST i API_PORT su postavljeni na defaultne vrijednosti prilikom build-a, 
ukoliko je potrebna promjena vrijednosti API_HOST ili API_PORT, potrebno je izvršiti komande:
     flutter clean
     flutter build windows --dart-define=API_HOST=NOVI_HOST --dart-define=API_PORT=NOVI_PORT (desktop)
     flutter build apk --dart-define=API_HOST=NOVI_HOST --dart-define=API_PORT=NOVI_PORT (mobile)

