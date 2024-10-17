using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class NarudzbaInsert
    {

        //public int? NarudzbaStavkeId { get; set; }

        public DateTime? DatumNarudzbe { get; set; }

        public DateTime? DatumIsporuke { get; set; }

        public bool? ZavrsenaNarudzba { get; set; }

        public int? PopustId { get; set; }
        [JsonIgnore]
        public decimal? UkupnaCijenaNarudzbe { get; set; }

    }
}
