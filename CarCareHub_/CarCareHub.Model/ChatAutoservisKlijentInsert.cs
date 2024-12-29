using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class ChatAutoservisKlijentInsert
    {
        public int KlijentId { get; set; }
        public int AutoservisId { get; set; }
        public string Poruka { get; set; }
     //   public bool PoslanoOdKlijenta { get; set; }
        public DateTime VrijemeSlanja { get; set; }
    }
}
