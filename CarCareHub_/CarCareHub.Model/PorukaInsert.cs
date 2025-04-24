using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class PorukaInsert
    {
        public string Sadrzaj { get; set; }
        public DateTime VrijemeSlanja { get; set; }
        public int? ChatKlijentAutoservisId { get; set; }
        public int? ChatKlijentZaposlenikId { get; set; } 
    }
}
