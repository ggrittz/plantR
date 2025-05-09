test_that("fixCase works", {

  spp <- c("Lindsaea lancea",
           "lindsaea lancea",
           "lindsaea Lancea",
           "Lindsaea Lancea",
           "LINDSAEA LANCEA",
           "Lindsaea lancea var. Angulata",
           "Lindsaea lancea (L.) Bedd.",
           "Lindsaea Lancea (L.) Bedd.",
           "lindsaea lancea (L.) Bedd.",
           "Lindsaea",
           "Lindsaea Dryand. ex Sm.",
           "LINDSAEA",
           "LINDSAEA Dryand. ex Sm.",
           "LINDSAEA LANCEA (L.) Bedd.",
           "Lindsaea lancea var. angulata Rosenst.",
           "Lindsaea lancea angulata Rosenst.",
           "LINDSAEA LANCEA ANGULATA Rosenst.",
           "Blechnum antillanum Proctor",
           "Blechnum occidentale leopoldense Dutra",
           "Blechnum occidentale var. leopoldense Dutra",
           "Cf. Australe",
           "Urbanodendron Mez",
           "Urbanodendron aubl.",
           "× Bensteinia ramonensis Pupulin",
           "Juglans microcarpa x Juglans regia",
           "Syzygium sp. DIR045",
           "Tragia sp. Philippines")

  res <- c("Lindsaea lancea",
           "Lindsaea lancea",
           "Lindsaea lancea",
           "Lindsaea lancea",
           "Lindsaea lancea",
           "Lindsaea lancea var. angulata",
           "Lindsaea lancea (L.) Bedd.",
           "Lindsaea lancea (L.) Bedd.",
           "Lindsaea lancea (L.) Bedd.",
           "Lindsaea",
           "Lindsaea Dryand. ex Sm.",
           "Lindsaea",
           "Lindsaea Dryand. ex Sm.",
           "Lindsaea lancea (L.) Bedd.",
           "Lindsaea lancea var. angulata Rosenst.",
           "Lindsaea lancea angulata Rosenst.",
           "Lindsaea lancea angulata Rosenst.",
           "Blechnum antillanum Proctor",
           "Blechnum occidentale leopoldense Dutra",
           "Blechnum occidentale var. leopoldense Dutra",
           "Cf. Australe",
           "Urbanodendron mez",
           "Urbanodendron aubl.",
           "× Bensteinia ramonensis Pupulin",
           "Juglans microcarpa x Juglans regia",
           "Syzygium sp. DIR045",
           "Tragia sp. Philippines")

  expect_equal(as.character(fixCase(spp)), res)
})
