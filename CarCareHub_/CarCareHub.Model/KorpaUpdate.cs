using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class KorpaUpdate
    {
        public int? ProizvodId { get; set; }
        public int? Kolicina { get; set; }
        [JsonIgnore]
        public decimal? UkupnaCijenaProizvoda { get; set; }
    }
}
