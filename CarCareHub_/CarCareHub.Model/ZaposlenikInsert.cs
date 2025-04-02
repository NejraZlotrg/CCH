using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ZaposlenikInsert
    {
        public string? Ime { get; set; }

        public string? Prezime { get; set; }

        public DateTime? DatumRodjenja { get; set; }

        [RegularExpression(@"^\d{12}$", ErrorMessage = "Matični broj mora imati tačno 12 cifara.")]
        public string? mb { get; set; } // Matični broj kao string


        public int? BrojTelefona { get; set; } 
        public int? GradId { get; set; }
        public bool Vidljivo { get; set; }


        public string? Email { get; set; }

        public string? Username { get; set; }

        [Compare("PasswordAgain", ErrorMessage = "Pass don't match")]

        public string? Password { get; set; }

        [Compare("Password", ErrorMessage="Pass don't match")]
        public string? PasswordAgain { get; set; }


        public int? UlogaId { get; set; }

        public int? AutoservisId { get; set; }

        public int? FirmaAutodijelovaId { get; set; }

        //public virtual Autoservi? Autoservis { get; set; }

        //public virtual ICollection<ChatKlijentZaposlenik> ChatKlijentZaposleniks { get; set; } = new List<ChatKlijentZaposlenik>();

        //public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }


        //public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();
    }
}
