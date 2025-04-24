using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Model.SearchObjects
{
    public class NarudzbaStavkaSearchObject : BaseSearchObject
    {

        public bool IsAllncluded { get; set; }
        public int? NarudzbaId { get; set; }

    }
}
