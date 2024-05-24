using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Zaposlenik
    {
            public int ZaposlenikId { get; set; }

            public string? Ime { get; set; }

            public string? Prezime { get; set; }
        public int? MaticniBroj { get; set; } //dodala
        public int? BrojTelefona { get; set; } //dodala
        public Grad? Grad { get; set; }
        public int? GradId { get; set; }

        public DateTime? DatumRodjenja { get; set; }

            public string? Email { get; set; }

            public string? Username { get; set; }
            public string? LozinkaSalt { get; set; }
            public string? LozinkaHash { get; set; }

        // public virtual ICollection<Uloge> Uloges { get; set; } = new List<Uloge>();

        public string? Password { get; set; }


        public int? UlogaId { get; set; }
        public virtual Uloge? Uloga { get; set; }

      
        public int? AutoservisId { get; set; }
        public virtual Autoservis? Autoservis { get; set; }

        
        public int? FirmaAutodijelovaId { get; set; }
        public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }


    }

}
