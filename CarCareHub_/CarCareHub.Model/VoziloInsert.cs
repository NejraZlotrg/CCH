using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class VoziloInsert
    {
        [Required(ErrorMessage = "Marka vozila je obavezna.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Marka vozila mora imati između 2 i 50 karaktera.")]
        public string? MarkaVozila { get; set; }

        public bool? Vidljivo { get; set; } = true;
    }
}
