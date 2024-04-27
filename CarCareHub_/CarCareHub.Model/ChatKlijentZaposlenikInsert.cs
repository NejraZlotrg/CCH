using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ChatKlijentZaposlenikInsert
    {
       //automatski
        public DateTime VrijemeZadnjePoruke { get; set; }


        public int? ZaposlenikId { get; set; }
        public int? KlijentId { get; set; }
       // public virtual ICollection<Poruka> Poruka { get; set; }
    }
}
