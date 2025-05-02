using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class KlijentInsert
    {
        [Required(ErrorMessage = "Ime je obavezno.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Ime mora imati između 2 i 50 karaktera.")]
        public string? Ime { get; set; }

        [Required(ErrorMessage = "Prezime je obavezno.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Prezime mora imati između 2 i 50 karaktera.")]
        public string? Prezime { get; set; }

        public bool? Vidljivo { get; set; } = true;

        [Required(ErrorMessage = "Email je obavezan.")]
        [EmailAddress(ErrorMessage = "Email nije u ispravnom formatu.")]
        public string? Email { get; set; }

        [Required(ErrorMessage = "Korisničko ime je obavezno.")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Korisničko ime mora imati između 3 i 50 karaktera.")]
        public string? Username { get; set; }

        [Required(ErrorMessage = "Lozinka je obavezna.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Lozinka mora imati između 6 i 100 karaktera.")]
        [Compare("PasswordAgain", ErrorMessage = "Lozinke se ne poklapaju.")]
        public string? Password { get; set; }

        [Required(ErrorMessage = "Potvrda lozinke je obavezna.")]
        [Compare("Password", ErrorMessage = "Lozinke se ne poklapaju.")]
        public string? PasswordAgain { get; set; }

        [StringLength(10, ErrorMessage = "Spol može imati najviše 10 karaktera.")]
        public string? Spol { get; set; }

        [Phone(ErrorMessage = "Broj telefona nije u ispravnom formatu.")]
        public string? BrojTelefona { get; set; }

        [StringLength(200, ErrorMessage = "Adresa može imati najviše 200 karaktera.")]
        public string? Adresa { get; set; }

        public int? GradId { get; set; }

        [Required(ErrorMessage = "Uloga je obavezna.")]
        public int UlogaId { get; set; }
    }
}
