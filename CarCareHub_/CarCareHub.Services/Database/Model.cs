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
        public virtual ICollection<Godiste> Godistes { get; set; } = new List<Godiste>(); //Njera dodala za modele



    }
}
