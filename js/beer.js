;(function () {
  var beers = document.querySelectorAll('.beer')

  Array.prototype.forEach.call(beers, function (beer) {
    beer.addEventListener('click', function (e) {
      e.preventDefault();
      if (beer.classList.contains('beer--open'))
        beer.classList.remove('beer--open')
      else
        beer.classList.add('beer--open')
    })
  })
})()
