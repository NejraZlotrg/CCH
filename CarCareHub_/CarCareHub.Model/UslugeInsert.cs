using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class UslugeInsert
    {
        [Required(ErrorMessage = "Naziv usluge je obavezan.")]
        [StringLength(100, MinimumLength = 3, ErrorMessage = "Naziv usluge mora imati između 3 i 100 karaktera.")]
        public string? NazivUsluge { get; set; }

        [StringLength(500, ErrorMessage = "Opis ne smije biti duži od 500 karaktera.")]
        public string? Opis { get; set; }

        [Required(ErrorMessage = "Cijena je obavezna.")]
        [Range(0.01, 1000000, ErrorMessage = "Cijena mora biti veća od 0.")]
        public decimal? Cijena { get; set; }

        public bool? Vidljivo { get; set; } = true;

        [Required(ErrorMessage = "AutoservisId je obavezan.")]
        public int? AutoservisId { get; set; }
    }
}
