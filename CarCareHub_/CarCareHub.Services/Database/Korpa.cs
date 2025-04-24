using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.Database
{
    public class Korpa
    {
        public int KorpaId { get; set; }
        public virtual ICollection<NarudzbaStavka> NarudzbaStavkas { get; set; } = new List<NarudzbaStavka>();
        public bool Vidljivo { get; set; }
        public int? ProizvodId { get; set; }
        public virtual Proizvod? Proizvod { get; set; }
        public int? KlijentId { get; set; }
        public virtual Klijent? Klijent { get; set; }
        public int? AutoservisId { get; set; }
        public virtual Autoservis? Autoservis { get; set; }
        public int? ZaposlenikId { get; set; }
        public virtual Zaposlenik? Zaposlenik { get; set; }
        public int? Kolicina { get; set; }
        public decimal? UkupnaCijenaProizvoda { get; set; }
    }
}
