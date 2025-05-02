using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class UlogeInsert
    {
        [Required(ErrorMessage = "Naziv uloge je obavezan.")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Naziv uloge mora imati između 3 i 50 karaktera.")]
        public string? NazivUloge { get; set; }

        public bool? Vidljivo { get; set; } = true;
    }
}
