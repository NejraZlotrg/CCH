using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class ModelSearchObject : BaseSearchObject
    {
        public string? NazivModela { get; set; }
        public bool? IsAllIncluded { get; set; }
        public string? MarkaVozila { get; set; }
        public int? Godiste_ { get; set; } //dodati implementaciju, obrisati ovaj komentar 



    }
}
