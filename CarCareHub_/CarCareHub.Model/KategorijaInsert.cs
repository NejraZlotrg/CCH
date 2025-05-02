using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class KategorijaInsert
    {
        [Required(ErrorMessage = "Naziv kategorije je obavezan.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv kategorije mora imati između 2 i 100 karaktera.")]
        public string? NazivKategorije { get; set; }

        public bool? Vidljivo { get; set; } = true;
    }
}
