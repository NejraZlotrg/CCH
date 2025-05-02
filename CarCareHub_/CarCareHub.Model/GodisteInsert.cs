using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class GodisteInsert
    {
        [Required(ErrorMessage = "Godina je obavezna.")]
        [Range(1800, int.MaxValue, ErrorMessage = "Godina mora biti veća od 1800.")]
        public int? Godiste_ { get; set; }

        public bool? Vidljivo { get; set; } = true;
    }
}
