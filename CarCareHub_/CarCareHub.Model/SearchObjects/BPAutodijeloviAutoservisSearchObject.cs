using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class BPAutodijeloviAutoservisSearchObject : BaseSearchObject
    {
        public bool? IsAllIncluded { get; set; }
        public int? AutodijeloviID { get; set; }
        public int? AutoservisID { get; set; }

    }
}
