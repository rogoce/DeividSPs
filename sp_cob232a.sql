-- Reporte del Cierre de Caja - Detallado

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_cierre_caja_automatico_reporte - DEIVID, S.A.
  
--drop procedure sp_cob232a;

create procedure "informix".sp_cob232a(a_no_caja char(10))
returning char(10),
          char(1),
          char(30),
          char(50),
          char(10),
          date,
          char(50),
          smallint,
          smallint,
          dec(16,2),
          smallint,
          smallint;

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
importe			dec(16,2)
) with no log;

select fecha,
       cod_chequera,
	   en_balance
  into _fecha,
       _cod_chequera,
	   _en_balance
  from cobcieca
 where no_caja = a_no_caja;

select nombre
  into _nombre_caja
  from chqchequ
 where cod_banco    = "146"
   and cod_chequera = _cod_chequera;

foreach

 select no_remesa,
        recibi_de
   into _no_remesa,
        _recibi_de
   from cobremae
  where fecha        = _fecha
    and cod_chequera = _cod_chequera
	and actualizado  = 1

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
		values (_no_remesa, _renglon, _no_recibo, _tipo_mov, _doc_remesa, _recibi_de, null, null, null);		
						    
	end foreach

	foreach
	 select renglon,
	        tipo_pago,
			tipo_tarjeta,
			importe
	   into _renglon,
	        _tipo_pago,
			_tipo_tarjeta,
			_importe
	   from cobrepag
	  where no_remesa = _no_remesa

		select count(*)
		  into _cantidad
		  from tmp_caja
		 where no_remesa = _no_remesa 
		   and renglon   = _renglon;

		if _cantidad <> 0 then

			update tmp_caja
			   set tipo_pago    = _tipo_pago,
			       tipo_tarjeta = _tipo_tarjeta,
				   importe      = _importe
			 where no_remesa    = _no_remesa
			   and renglon      = _renglon;

		else

			insert into tmp_caja
			values (_no_remesa, _renglon, "", "P", "", "", _tipo_pago, _tipo_tarjeta, _importe);		

		end if

	end foreach

end foreach

let _tipo_dato = 1;

foreach
 select no_recibo,	 
		tipo_mov,	
		doc_remesa,
		recibi_de,
		tipo_pago,
		tipo_tarjeta, 
		importe	
   into _no_recibo,	 
		_tipo_mov,	
		_doc_remesa,
		_recibi_de,
		_tipo_pago,
		_tipo_tarjeta, 
		_importe	
   from tmp_caja
  order by no_recibo

		if _tipo_pago <> 4 then
			let _tipo_tarjeta = 0;
		end if
   
		let _tipo_pago = _tipo_pago + _tipo_tarjeta;

		return _no_recibo, 
		       _tipo_mov,
			   _doc_remesa,
			   _recibi_de,
			   a_no_caja,
			   _fecha,
			   _nombre_caja,
			   _tipo_pago,
			   _tipo_tarjeta, 
			   _importe,
			   _en_balance,
			   _tipo_dato	
			   with resume;
	
end foreach   		

let _tipo_dato = 2;

foreach
 select tipo_pago,
		tipo_tarjeta, 
		monto,
		cuenta,
		nombre	
   into _tipo_pago,
		_tipo_tarjeta, 
		_importe,
		_doc_remesa,
		_recibi_de	
   from cobcieca2
  where no_caja = a_no_caja
  order by renglon

		if _tipo_pago <> 4 then
			let _tipo_tarjeta = 0;
		end if
   
		if _tipo_pago = 6 then
			let _tipo_pago = 1;
		end if

		let _tipo_pago = _tipo_pago + _tipo_tarjeta;

		return "", 
		       "P",
			   _doc_remesa,
			   _recibi_de,
			   a_no_caja,
			   _fecha,
			   _nombre_caja,
			   _tipo_pago,
			   _tipo_tarjeta, 
			   _importe,
			   _en_balance,
			   _tipo_dato	
			   with resume;

end foreach   		

--drop table tmp_caja;

end procedure