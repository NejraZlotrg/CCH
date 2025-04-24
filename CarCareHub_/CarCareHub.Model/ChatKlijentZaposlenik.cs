using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ChatKlijentZaposlenik
    {
        public int ChatKlijentZaposlenikId { get; set; }
        public int KlijentId { get; set; }
        public virtual Klijent Klijent { get; set; }
        public virtual Zaposlenik Zaposlenik { get; set; }
        public int ZaposlenikId { get; set; }
        public string Poruka { get; set; }
        public bool PoslanoOdKlijenta { get; set; }
        public DateTime VrijemeSlanja { get; set; }
    }
}
