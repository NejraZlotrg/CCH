using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class GradInsert
    {
        [Required(ErrorMessage = "Naziv grada je obavezan.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv grada mora imati između 2 i 100 karaktera.")]
        public string? NazivGrada { get; set; }

        [Required(ErrorMessage = "DržavaId je obavezno.")]
        public int? DrzavaId { get; set; }

        public bool? Vidljivo { get; set; } = true;
    }
}
