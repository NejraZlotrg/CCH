using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class ModelInsert
    {
        [Required(ErrorMessage = "Naziv modela je obavezan.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv modela mora imati između 2 i 50 karaktera.")]
        public string? NazivModela { get; set; }

        [Required(ErrorMessage = "VoziloId je obavezan.")]
        public int VoziloId { get; set; }

        [Required(ErrorMessage = "GodišteId je obavezan.")]
        public int GodisteId { get; set; }

        public bool? Vidljivo { get; set; } = true;
    }
}
