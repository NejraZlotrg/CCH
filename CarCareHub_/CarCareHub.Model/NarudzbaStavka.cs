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
        public int? ProizvodId { get; set; }

        public virtual Proizvod? Proizvod { get; set; }

        public int Kolicina { get; set; }

        public int? NarudzbaId { get; set; }

        public virtual Narudzba? Narudzba { get; set; }
    }
}
