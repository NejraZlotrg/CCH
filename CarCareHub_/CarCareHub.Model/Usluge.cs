using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Usluge
    {
        public int UslugeId { get; set; }

        public string? NazivUsluge { get; set; }

        public string? Opis { get; set; }

        public decimal? Cijena { get; set; }

    }
}
