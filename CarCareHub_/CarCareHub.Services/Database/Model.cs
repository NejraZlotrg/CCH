using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.Database
{
    public class Model
    {
        public int ModelId { get; set; }
        public string? NazivModela { get; set; }
        public int VoziloId { get; set; }
        public Vozilo? Vozilo {get;set;}
        public bool Vidljivo { get; set; }
        public int GodisteId { get; set; }
        public Godiste? Godiste { get; set; }



    }
}
