-- Reporte del Cierre de Caja - Detallado

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_cierre_caja_automatico_reporte - DEIVID, S.A.
  
drop procedure sp_cob232bk;

create procedure "informix".sp_cob232bk(a_no_caja char(10))
returning char(80),
          smallint;

define _cod_chequera 	char(3); 
define _nombre_caja		char(50);
define _fecha 			date; 
define _en_balance		smallint;

define _no_remesa		char(10);
define _recibi_de		char(50);
define _no_recibo		char(10);
define _tipo_mov		char(1);
define _tipo_remesa		char(1);
define _doc_remesa		char(30);
define _observacion		varchar(100);

define _contador		smallint;
define _cantidad,_cnt,_cnt2  smallint;

define _tipo_pago		smallint;
define _tipo_tarjeta	smallint;
define _renglon			smallint;
define _importe			dec(16,2);
define _tipo_dato,_flag	smallint;
define _cod_cobra       char(3);
define _cod_libreta     char(5);
define _no_rec_ini      integer;
define _no_rec_fin      integer;

define _no_recibo_min,_no_recibo_max,_rango_recibo1   integer;
define _no_recibo_min_c char(10);

set isolation to dirty read;

create temp table tmp_caja(
no_remesa		char(10),
renglon			smallint,
no_recibo		char(10),
tipo_mov		char(1),
doc_remesa		char(30),
recibi_de		char(50),
tipo_pago		smallint,
tipo_tarjeta	smallint,
importe			dec(16,2),
tipo_remesa		char(1)
) with no log;

--Return "",0;

select fecha,
       cod_chequera,
	   en_balance,
	   tipo_remesa
  into _fecha,
       _cod_chequera,
	   _en_balance,
	   _tipo_remesa
  from cobcieca
 where no_caja = a_no_caja;

select nombre
  into _nombre_caja
  from chqchequ
 where cod_banco    = "146"
   and cod_chequera = _cod_chequera;

foreach
 select no_remesa,
        recibi_de,
		tipo_remesa
   into _no_remesa,
        _recibi_de,
		_tipo_remesa
   from cobremae
  where fecha        = _fecha
    and cod_chequera = _cod_chequera
	and actualizado  = 1
	and tipo_remesa  = _tipo_remesa

  select cod_cobrador
    into _cod_cobra
    from cobremae
   where no_remesa = _no_remesa;

	let _contador = 0;
	  
	foreach
	 select renglon,
	        no_recibo,
	        tipo_mov,
			doc_remesa
	   into _renglon,
	        _no_recibo,
	        _tipo_mov,
			_doc_remesa
	   from cobredet
	  where no_remesa = _no_remesa

		let _contador = _contador + 1;

		if _contador > 1 then
			let _recibi_de = "";
		end if
		
		insert into tmp_caja
		values (_no_remesa, _renglon, _no_recibo, _tipo_mov, _doc_remesa, _recibi_de, null, null, null,_tipo_remesa);		
						    
	end foreach

end foreach

{select cod_libreta
  into _cod_libreta
  from cobcobra
 where cod_cobrador = _cod_cobra;

select rango_recibo1
  into _rango_recibo1
  from coblibre
 where cod_libreta = _cod_libreta;}
 

foreach
 select no_recibo
   into _no_recibo_min
   from tmp_caja
  where tipo_remesa not in ('F') -- Remesa de cierre de caja
  order by no_recibo

  exit foreach;
end foreach

let _flag = 0;

foreach
 select no_recibo,	 
		tipo_mov,	
		doc_remesa,
		recibi_de,
		tipo_pago,
		tipo_tarjeta, 
		importe,
		tipo_remesa	
   into _no_recibo,	 
		_tipo_mov,	
		_doc_remesa,
		_recibi_de,
		_tipo_pago,
		_tipo_tarjeta, 
		_importe,
		_tipo_remesa	
   from tmp_caja
  where tipo_remesa not in ('F') --Remesa de cierre de caja
  order by no_recibo

  let _no_recibo_min_c = "";

  if (_no_recibo - _no_recibo_min) > 1 then

	 select count(*)
	   into _cnt
	   from coblibre
	  where rango_recibo1 = _no_recibo;
																															
      if _cnt > 0 then

		 select count(*)
		   into _cnt
		   from coblibre
		  where rango_recibo2 = _no_recibo_min;

	     if _cnt > 0 then
		 else

	  	     let _no_recibo_min = _no_recibo_min + 1;
			 let _flag = 1;
			 exit foreach;
		 end if
	  else

		 foreach
			 select no_recibo
			   into _no_rec_ini
			   from tmp_caja
		      where tipo_remesa not in ('F')
			  order by no_recibo

			 exit foreach;
		 end foreach

		 foreach
			 select no_recibo
			   into _no_rec_fin
			   from tmp_caja
		      where tipo_remesa not in ('F')
			  order by no_recibo desc

			 exit foreach;
		 end foreach

	 	 select count(*)
		   into _cnt
		   from coblibre
		  where rango_recibo1 = _no_rec_ini;

		 select count(*)
		   into _cnt2
		   from coblibre
		  where rango_recibo2 = _no_rec_fin;

		 if _cnt = 1 and _cnt2 = 1 then
		 else
	  	     let _no_recibo_min = _no_recibo_min + 1;
			 let _no_recibo_min_c = _no_recibo_min;
             select count(*)
			   into _cnt
               from cobredet
		   	  where no_recibo = _no_recibo_min_c
				and tipo_mov = 'B';
			  if _cnt > 0 then
			  else
				 let _flag = 1;
				 exit foreach;
			  end if
		 end if
	  end if

  end if
     
  let _no_recibo_min = _no_recibo;
	
end foreach

--drop table tmp_caja;

if _flag = 1 then
	return "No Puede Cerrar la Caja, Falta Recibo en la Secuencia." || _no_recibo_min, 1;
end if

Return "",0;

end procedure