using System;
using System.ComponentModel.DataAnnotations;

namespace CarCareHub.Model
{
    public class ProizvodjacInsert
    {
        [Required(ErrorMessage = "Naziv proizvođača je obavezan.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv proizvođača mora imati između 2 i 100 karaktera.")]
        public string? NazivProizvodjaca { get; set; }

        public bool? Vidljivo { get; set; } = true;
    }
}
