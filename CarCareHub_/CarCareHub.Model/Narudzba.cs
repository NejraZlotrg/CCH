using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Narudzba
    {
        public int NarudzbaId { get; set; }

      //  public int? NarudzbaStavkeId { get; set; }

        public DateTime? DatumNarudzbe { get; set; }

        public DateTime? DatumIsporuke { get; set; }

        public bool? ZavrsenaNarudzba { get; set; }
        public int? KlijentId { get; set; }
      //  public virtual Klijent? Klijent { get; set; }


        public int? AutoservisId { get; set; }
      //  public virtual Autoservis? Autoservis { get; set; }


        public int? ZaposlenikId { get; set; }
      //  public virtual Zaposlenik? Zaposlenik { get; set; }

        public int? PopustId { get; set; }
        public decimal? UkupnaCijenaNarudzbe { get; set; }
        public bool Vidljivo { get; set; }
    }
}
