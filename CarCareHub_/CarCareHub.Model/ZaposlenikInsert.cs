using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class ZaposlenikInsert
    {
        [Required(ErrorMessage = "Ime je obavezno.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Ime mora imati između 2 i 50 karaktera.")]
        public string? Ime { get; set; }

        [Required(ErrorMessage = "Prezime je obavezno.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Prezime mora imati između 2 i 50 karaktera.")]
        public string? Prezime { get; set; }

        [Required(ErrorMessage = "Datum rođenja je obavezan.")]
        [DataType(DataType.Date)]
        public DateTime? DatumRodjenja { get; set; }

        [Required(ErrorMessage = "Matični broj je obavezan.")]
        [RegularExpression(@"^\d{13}$", ErrorMessage = "Matični broj mora imati tačno 13 cifara.")]
        public string? mb { get; set; }

        [Required(ErrorMessage = "Broj telefona je obavezan.")]
        [Phone(ErrorMessage = "Neispravan format broja telefona.")]
        public string? BrojTelefona { get; set; }

        [Required(ErrorMessage = "Grad je obavezan.")]
        public int? GradId { get; set; }

        public bool Vidljivo { get; set; } = true;

        [Required(ErrorMessage = "Email je obavezan.")]
        [EmailAddress(ErrorMessage = "Neispravan format email adrese.")]
        public string? Email { get; set; }

        [Required(ErrorMessage = "Adresa je obavezna.")]
        [StringLength(100, MinimumLength = 5, ErrorMessage = "Adresa mora imati između 5 i 100 karaktera.")]
        public string? Adresa { get; set; }

        [Required(ErrorMessage = "Korisničko ime je obavezno.")]
        [StringLength(30, MinimumLength = 4, ErrorMessage = "Korisničko ime mora imati između 4 i 30 karaktera.")]
        public string? Username { get; set; }

        [Required(ErrorMessage = "Lozinka je obavezna.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Lozinka mora imati najmanje 6 karaktera.")]
        [Compare("PasswordAgain", ErrorMessage = "Lozinke se ne podudaraju.")]
        public string? Password { get; set; }

        [Required(ErrorMessage = "Potvrda lozinke je obavezna.")]
        [Compare("Password", ErrorMessage = "Lozinke se ne podudaraju.")]
        public string? PasswordAgain { get; set; }

        [Required(ErrorMessage = "Uloga je obavezna.")]
        public int? UlogaId { get; set; }

        public int? AutoservisId { get; set; }

        public int? FirmaAutodijelovaId { get; set; }
    }
}
