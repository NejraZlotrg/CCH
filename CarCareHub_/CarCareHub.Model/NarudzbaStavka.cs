using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class NarudzbaStavka
    {
        

        public int? KorpaId { get; set; }

        public virtual Korpa? Korpa { get; set; }
        public int? NarudzbaId { get; set; }

        public virtual Narudzba? Narudzba { get; set; }
    }
}
