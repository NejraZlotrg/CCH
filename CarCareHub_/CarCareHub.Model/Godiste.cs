using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model
{
    public class Godiste
    {
        public int GodisteId { get; set; }
        public int? Godiste_ { get; set; }
        public int? ModelId { get; set; }
        public Model? Model { get; set; }
    }
}
