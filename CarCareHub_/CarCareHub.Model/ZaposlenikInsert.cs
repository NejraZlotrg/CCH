using System;
using System.Collections.Generic;
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

        public string? Email { get; set; }

        public string? Username { get; set; }

        public string? Password { get; set; }

        public int? UlogaId { get; set; }

        public int? AutoservisId { get; set; }

        public int? FirmaAutodijelovaId { get; set; }

        //public virtual Autoservi? Autoservis { get; set; }

        //public virtual ICollection<ChatKlijentZaposlenik> ChatKlijentZaposleniks { get; set; } = new List<ChatKlijentZaposlenik>();

        //public virtual FirmaAutodijelova? FirmaAutodijelova { get; set; }

        //public virtual Uloge? Uloga { get; set; }

        //public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();
    }
}
