using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Klijent
    {
        public int KlijentId { get; set; }
        public string? Ime { get; set; }
        public string? Prezime { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }
        public bool Vidljivo { get; set; }
        public string? Password { get; set; }
        public string? LozinkaSalt { get; set; }
        public string? LozinkaHash { get; set; }
        public string? Spol { get; set; }
        public string? BrojTelefona { get; set; }
        public string? Adresa { get; set; }
        public int? GradId { get; set; }
        public virtual Grad? Grad { get; set; }
        public int UlogaId { get; set; }
        public virtual Uloge uloga { get; set; }
    }
}
