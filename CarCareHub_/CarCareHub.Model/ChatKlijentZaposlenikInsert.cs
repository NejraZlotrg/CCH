using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ChatKlijentZaposlenikInsert
    {
        public int KlijentId { get; set; }
        public int ZaposlenikId { get; set; }
        public string Poruka { get; set; }
        //   public bool PoslanoOdKlijenta { get; set; }
        public DateTime VrijemeSlanja { get; set; }
    }
}
