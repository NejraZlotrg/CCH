
using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Trainers;

namespace CarCareHub.Services
{
    public class RecommenderService : IRecommenderService
    {
        private readonly CchV2AliContext _dbContext;
        private static MLContext? _mlContext;
        private static object isLocked = new();
        private static ITransformer? _model; 
        private readonly IMapper _mapper;


        public RecommenderService(CchV2AliContext dbContext, IMapper mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }


        public async Task<List<Database.Proizvod>> GetRecommendationsByArticleId(long articleId, CancellationToken cancellationToken)
        {
            var entity = await _dbContext.Recommenders.FirstOrDefaultAsync(x => x.ProizvodId == articleId, cancellationToken);

            if (entity is null)
            {
                Console.WriteLine($"Nema preporuka za proizvod ID: {articleId}");
                return new();
            }

         

            var recommendedArticleIds = new List<long>();

            recommendedArticleIds.Add(entity.PrvaPreporukaId ?? 0);
            recommendedArticleIds.Add(entity.DrugaPreporukaId ?? 0);
            recommendedArticleIds.Add(entity.TrecaPreporukaId ?? 0);

            var articles = await _dbContext.Proizvods
                .Where(x => recommendedArticleIds.Contains(x.ProizvodId))
                .ToListAsync(cancellationToken);

            return articles;
        }

        private List<Database.Proizvod> Recommend(long articleId)
        {
            lock (isLocked)
            {
                if (_mlContext == null)
                {
                    _mlContext = new MLContext();

                    var tmpData = _dbContext.NarudzbaStavkas.Include(x => x.Proizvod).ToList();

                    var data = new List<ArticleRecommendation>();

                    foreach (var x in tmpData)
                    {
                        var distinctItemId = tmpData.Select(y => y.ProizvodId).ToList();

                        distinctItemId?.ForEach(y =>
                        {
                            var relatedItems = tmpData.Select(z => z.ProizvodId).Where(z => z != y);

                            foreach (var z in relatedItems)
                            {
                                data.Add(new ArticleRecommendation
                                {
                                    ProizvodId = (uint)y,
                                    CoProizvodId = (uint)z
                                });
                            }
                        });
                    }

                    var trainData = _mlContext.Data.LoadFromEnumerable(data);

                    MatrixFactorizationTrainer.Options options = new MatrixFactorizationTrainer.Options();
                    options.MatrixColumnIndexColumnName = nameof(ArticleRecommendation.ProizvodId);
                    options.MatrixRowIndexColumnName = nameof(ArticleRecommendation.CoProizvodId);
                    options.LabelColumnName = "Label";

                    options.LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass;
                    options.Alpha = 0.01;
                    options.Lambda = 0.025;

                    options.NumberOfIterations = 100;
                    options.C = 0.00001;

                    var est = _mlContext.Recommendation().Trainers.MatrixFactorization(options);

                    _model = est.Fit(trainData);
                }
            }

            var articles = _dbContext.Proizvods.Where(x => x.ProizvodId != articleId).ToList();

            var predictionResult = new List<Tuple<Database.Proizvod, float>>();

            foreach (var proizvod in articles)
            {
                var predictionEngine = _mlContext.Model.CreatePredictionEngine<ArticleRecommendation, CoArticlePrediction>(_model);

                var prediction = predictionEngine.Predict(new ArticleRecommendation
                {
                    ProizvodId = (uint)articleId,
                    CoProizvodId = (uint)proizvod.ProizvodId
                });

                predictionResult.Add(new Tuple<Database.Proizvod, float>(proizvod, prediction.Score));
            }

            var finalResult = predictionResult.OrderByDescending(x => x.Item2).Select(x => x.Item1).Take(3).ToList();

            return _mapper.Map<List<Database.Proizvod>>(finalResult); 
        }

        public async Task<PagedResult<Database.Recommender>> TrainModelAsync(CancellationToken cancellationToken)
        {
            try
            {
                var articles = await _dbContext.Proizvods.ToListAsync(cancellationToken);


                // Bilo > 1 pa radilo
                if (articles.Count > 4)
                {
                    var recommendList = new List<Database.Recommender>();

                    foreach (var article in articles)
                    {
                        var recommendedArticles = Recommend(article.ProizvodId);

                        var result = new Database.Recommender
                        {
                            ProizvodId = article.ProizvodId,
                            PrvaPreporukaId = recommendedArticles[0].ProizvodId,
                            DrugaPreporukaId = recommendedArticles[1].ProizvodId,
                            TrecaPreporukaId = recommendedArticles[2].ProizvodId,
                        };

                        recommendList.Add(result);
                    }

                    await CreateNewRecommendation(recommendList, cancellationToken);
                    await _dbContext.SaveChangesAsync(cancellationToken);

                    return _mapper.Map<PagedResult<Database.Recommender>>(recommendList);

                }
                else
                {
                    throw new Exception("Not enough data to generate recommendations.");

                }
            }
            catch (Exception ex)
            {
                var o = ex;
                throw;
            }

        }

        private async Task CreateNewRecommendation(List<Database.Recommender> results, CancellationToken cancellationToken)
        {
            var existingRecommendations = await _dbContext.Recommenders.ToListAsync(cancellationToken);
            var articlesCount = await _dbContext.Proizvods.CountAsync(cancellationToken);
            var recommendationCount = await _dbContext.Recommenders.CountAsync(cancellationToken);

            if (recommendationCount != 0)
            {
                if (recommendationCount > articlesCount)
                {
                    for (int i = 0; i < articlesCount; i++)
                    {
                        existingRecommendations[i].ProizvodId = results[i].ProizvodId;
                        existingRecommendations[i].PrvaPreporukaId = results[i].PrvaPreporukaId;
                        existingRecommendations[i].DrugaPreporukaId = results[i].DrugaPreporukaId;
                        existingRecommendations[i].TrecaPreporukaId = results[i].TrecaPreporukaId;
                    }
                    for (int i = 0; i < recommendationCount; i++)
                    {
                        _dbContext.Recommenders.Remove(existingRecommendations[i]);
                    }
                }
                else
                {
                    for (int i = 0; i < recommendationCount; i++)
                    {
                        existingRecommendations[i].ProizvodId = results[i].ProizvodId;
                        existingRecommendations[i].PrvaPreporukaId = results[i].PrvaPreporukaId;
                        existingRecommendations[i].DrugaPreporukaId = results[i].DrugaPreporukaId;
                        existingRecommendations[i].TrecaPreporukaId = results[i].TrecaPreporukaId;
                    }

                    var num = results.Count - recommendationCount;

                    if (num > 0)
                    {
                        for (int i = results.Count - num; i < results.Count; i++)
                        {
                            await _dbContext.Recommenders.AddAsync(results[i], cancellationToken);
                        }
                    }
                }
            }
            else
            {
                await _dbContext.Recommenders.AddRangeAsync(results, cancellationToken);
            }
        }

    }
}
