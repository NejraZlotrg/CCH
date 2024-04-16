using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class GodisteSearchObject: BaseSearchObject
    {
        public int? Godiste_ { get; set; }

        public bool? IsAllIncluded { get; set; }
        public string? NazivModela { get; set; }

    }
}
