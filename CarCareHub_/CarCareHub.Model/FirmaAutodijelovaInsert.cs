using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class FirmaAutodijelovaInsert
    {
        [Required(ErrorMessage = "Naziv firme je obavezan.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv firme mora imati između 2 i 100 karaktera.")]
        public string? NazivFirme { get; set; }

        [StringLength(200, ErrorMessage = "Adresa može imati najviše 200 karaktera.")]
        public string? Adresa { get; set; }

        [Required(ErrorMessage = "GradId je obavezan.")]
        public int? GradId { get; set; }

        [Required(ErrorMessage = "JIB je obavezan.")]
        [StringLength(13, MinimumLength = 13, ErrorMessage = "JIB mora imati tačno 13 karaktera.")]
        public string? JIB { get; set; }

        [Required(ErrorMessage = "MBS je obavezan.")]
        [StringLength(9, MinimumLength = 9, ErrorMessage = "MBS mora imati tačno 9 karaktera.")]
        public string? MBS { get; set; }

        [Required(ErrorMessage = "UlogaId je obavezno.")]
        public int? UlogaId { get; set; }

        public bool? Vidljivo { get; set; } = true;

        [Phone(ErrorMessage = "Telefon nije u ispravnom formatu.")]
        public string? Telefon { get; set; }

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

        public byte[]? SlikaProfila { get; set; }
    }
}
