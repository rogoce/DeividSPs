  
drop procedure sp_leyri05;

create procedure "informix".sp_leyri05(a_fecha1 date, a_fecha2 date)
returning char(10),	 
          char(10),	 
          dec(16,2), 
          char(50),	 
          date,		 
		  char(30),
		  char(1);

define _cod_chequera 	char(3); 
define _nombre_caja		char(50);
define _fecha 			date; 
define _en_balance		smallint;

define _no_remesa		char(10);
define _recibi_de		char(50);
define _no_recibo		char(10);
define _tipo_mov		char(1);
define _doc_remesa		char(30);

define _contador		smallint;
define _cantidad		smallint;

define _tipo_pago		smallint;
define _tipo_tarjeta	smallint;
define _renglon			smallint;
define _importe			dec(16,2);
define _tipo_dato		smallint;
define _n_movimiento    char(50);
define _n_cobrador		char(30);
define _monto           dec(16,2);
define _cod_cobrador    char(3);
define _tipo_remesa		char(1);

set isolation to dirty read;

let _cod_cobrador = null;
foreach
 select no_remesa,
        recibi_de,
		cod_cobrador,
		fecha,
		tipo_remesa
   into _no_remesa,
        _recibi_de,
		_cod_cobrador,
		_fecha,
		_tipo_remesa
   from cobremae
  where fecha        between a_fecha1 and a_fecha2
    and tipo_remesa in("A","M","C")
	and actualizado  = 1
  order by fecha, no_remesa

  if _cod_cobrador is not null then
	select nombre
	  into _n_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;
  end if	

	foreach

		select no_recibo,
		       sum(monto)
		  into _no_recibo,
			   _monto
		  from cobredet
		 where no_remesa = _no_remesa
		   and renglon <> 0
		group by no_recibo
		order by no_recibo

{	  if _tipo_mov = "P" then
			let _n_movimiento = "Pago de Prima";
	  elif _tipo_mov = "N" then
			let _n_movimiento = "Nota de Credito";
	  elif _tipo_mov = "C" then
			let _n_movimiento = "Comision Descontada";
	  elif _tipo_mov = "D" then
			let _n_movimiento = "Pago deducible";
	  elif _tipo_mov = "S" then
			let _n_movimiento = "Pago Salvamento";
	  elif _tipo_mov = "R" then
			let _n_movimiento = "Pago Recupero";
	  elif _tipo_mov = "E" then
			let _n_movimiento = "Crear Prima Suspenso";
	  elif _tipo_mov = "A" then
			let _n_movimiento = "Aplicar Prima Suspenso";
	  elif _tipo_mov = "B" then
			let _n_movimiento = "Recibo Anulado";
	  elif _tipo_mov = "T" then
			let _n_movimiento = "Aplicar Reclamo";
	  elif _tipo_mov = "O" then
			let _n_movimiento = "Deuda Agente";
	  elif _tipo_mov = "M" then
			let _n_movimiento = "Afectacion Catalogo";
	  elif _tipo_mov = "X" then
			let _n_movimiento = "Elim. Centavo";
	  end if  }

		return _no_remesa,
			   _no_recibo, 
			   _monto,
			   _recibi_de,
			   _fecha,
			   _n_cobrador,
			   _tipo_remesa
			   with resume;


	end foreach
end foreach


end procedure