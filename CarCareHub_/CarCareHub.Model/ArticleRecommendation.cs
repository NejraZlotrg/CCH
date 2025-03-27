using Microsoft.ML.Data;

namespace CarCareHub.Model
{
    public class ArticleRecommendation
    {
        [KeyType(count: 27)]
        public uint ProizvodId { get; set; }
        [KeyType(count: 27)]
        public uint CoProizvodId { get; set; }
        public float Label { get; set; }
    }
}
