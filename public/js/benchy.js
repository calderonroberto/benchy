$( document ).ready(function() {

  var chart = Morris.Area({
    element: 'daily-balance',
    data: [
      { y: '2006', a: 0},
      { y: '2007', a: 0},
      { y: '2008', a: 0},
      { y: '2009', a: 0},
      { y: '2010', a: 0}
    ],
    xkey: 'y',
    ykeys: ['a'],
    labels: ['Balance'],
    resize: true,

  });

  $.ajax({
    url: '/balances'
  }).done(function (data){
    var chartData = [];
    for (var i in data){
      if (data.hasOwnProperty(i)){
        chartData.push({y:data[i].date, a:data[i].balance});
      }
    }
    chart.setData(chartData);
  });

  $.ajax({
    url: '/balance'
  }).done(function(data){
    $('#balance').html('$ '+data.balance);
  });

  /*Render Transactions*/
  $.ajax({
    url: '/transactions'
    }
  ).done(function(data){
    for ( var i in data) {
      if (data.hasOwnProperty(i)) {
        $('#transactions').append('<tr><td>'+data[i].date+'<td><td>'+data[i].ledger+'<td><td>'+data[i].company+'<td><td>'+data[i].amount+'<td></tr>');
      }
    }
  });

  $.ajax({
    url: '/categories'
  }).done(function(data){
    var categoryTables ="";
    for (var i in data) {
      if (data.hasOwnProperty(i)){
        categoryTables += '<div class="panel panel-default"><div class="panel-heading">'+data[i].category+'</div><table class="table"><caption>Total Balance: '+data[i].totalExpenses+'</caption';
        for (var j in data[i].transactions) {
          if (data[i].transactions.hasOwnProperty(j)){
            categoryTables +=  '<tr><td>'+data[i].transactions[j].date+'</td><td>'+data[i].transactions[j].company+'</td><td>'+data[i].transactions[j].amount+'<td><tr>';
          }
        }
        categoryTables += '</table></div>';
      }
    }
    $('#categories').append(categoryTables);
  });

});
