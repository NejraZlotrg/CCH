using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.Database
{
    public class Poruka
    {
        public int PorukaId { get; set; }
        public string Sadrzaj { get; set; }
        public DateTime VrijemeSlanja { get; set; }
        public int? ChatKlijentAutoservisId { get; set; }
        public int? ChatKlijentZaposlenikId { get; set; } 
        public virtual ChatKlijentZaposlenik? ChatKlijentZaposlenik { get; set; }
        public bool Vidljivo { get; set; }
    }
}
