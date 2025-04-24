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
    public int? Kolicina { get; set; }
        public int? KorpaId { get; set; }
        public int? NarudzbaId { get; set; }
        public bool Vidljivo { get; set; }
    }
}
