using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class NarudzbaStavkaInsert
    {

        public int? ProizvodId { get; set; }

        public int? Kolicina { get; set; }

        public int? NarudzbaId { get; set; }
        [JsonIgnore]
        public decimal? UkupnaCijenaProizvoda { get; set; }

        //[JsonIgnore]

        //public virtual Proizvod? Proizvod { get; set; }




    }
}
