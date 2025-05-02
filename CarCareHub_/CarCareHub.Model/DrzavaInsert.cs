using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class DrzavaInsert
    {
        [Required(ErrorMessage = "Naziv države je obavezan.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv države mora imati između 2 i 100 karaktera.")]
        public string? NazivDrzave { get; set; }

        public bool? Vidljivo { get; set; } = true;
    }
}
