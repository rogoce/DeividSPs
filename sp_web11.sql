-- Obtener el estado de los reclamos

-- Creado    : 15/02/2012 - Autor: Federico Coronado

-- SIS - Pagina Web reclamos poliza de la embajada.

drop procedure sp_web11;

create procedure "informix".sp_web11(a_no_documento char(15),a_cod_asegurado varchar(10))
returning char(20),
char(20),
varchar(10),
date,
char(40),
char(10),
char(10),
date,
char(30),
varchar(20),
integer,
integer,
integer,
char(10),
decimal(10,2),
decimal(10,2),
char(10),
char(3),
date,
varchar(5),
varchar(30),
dec(16,2),			
dec(16,2),			
dec(16,2),			
dec(16,2),			
dec(16,2),
varchar(50);

define _no_reclamo 			char(10);
define _no_factura 			varchar(10);
define _fecha_factura 		date;
define _no_documento 		char(20);
define _cod_asegurado 		char(10);
define _nombre_paciente 	char(40);
define _transaccion 		char(10);
define _pagado 				char(10);
define _no_requis 			char(20);
define _numrecla 			char(20);
define _fecha_reclamo 		date;
define _periodo				char(7);
define _tipotran 			char(3);
define _no_cheque 			char(10);
define _wf_fecha 			date;
define _wf_nombre 			char(30);
define _wf_cedula 			char(10);
define _cod_reclamante 		char(10);
define _cod_asignacion 		char(10);
define _cod_icd 			char(10);
define _cod_entrada 		char(10);
define _cod_tipopago 		char(3);
define _wf_pagado 			integer;
define _wf_entregado 		integer;
define _en_firma 			smallint;
define _no_unidad 			varchar(5);
define _cedula              varchar(30);
define _estatus				varchar(20);
define _no_tranrec 			varchar(10);
define _monto 				decimal(10,2);
define _gastos_no_cub 		decimal(10,2);
define _gasto_fact			dec(16,2);
define _gasto_eleg			dec(16,2);
define _a_deducible			dec(16,2);
define _co_pago				dec(16,2);
define _coaseguro			dec(16,2);
define _descripago			varchar(50);
let _wf_fecha   = NULL;

/*
let _fecha   = today;
let _fecha   = _fecha - 3 units month;
let _periodo = sp_sis39(_fecha);
*/

set isolation to dirty read;
--SET DEBUG FILE TO "sp_web11.trc";
--TRACE ON;   


foreach

	 SELECT recrcmae.no_reclamo,
	        recrcmae.numrecla,
	        no_factura,
	        fecha_factura,
            rectrmae.transaccion,
	        pagado,
	        no_requis,
	        cod_tipotran,
	        rectrmae.monto,
            no_tranrec,
            rectrmae.cod_asignacion,
		    recrcmae.cod_icd,
			fecha_documento,
			cod_tipopago,
			recrcmae.no_unidad
	   into _no_reclamo,
	        _numrecla,
	        _no_factura,
	        _fecha_factura,
	        _transaccion,
	        _pagado,
	        _no_requis,
		    _tipotran,
		    _monto,
		    _no_tranrec,
			_cod_asignacion,
			_cod_icd,
			_fecha_reclamo,
			_cod_tipopago,
			_no_unidad
FROM recrcmae inner join rectrmae on recrcmae.no_reclamo = rectrmae.no_reclamo
where recrcmae.cod_compania = "001"
and recrcmae.actualizado  = 1
/*and rectrmae.cod_tipopago = '003' /*pago a asegurado*/
and cod_tipotran in ('013', '004')
and anular_nt    is null
and rectrmae.transaccion is not null
and recrcmae.no_documento = a_no_documento
and recrcmae.cod_asegurado = a_cod_asegurado
order by fecha_factura DESC

	let _no_cheque 		= '';
	let _wf_pagado 		= '';
	let _wf_entregado	= '';
	let _wf_nombre 		= '';
	let _wf_cedula 		= '';
	let _descripago = '';
   if _tipotran = '013'	then

	   let _estatus = "Declinado";

	else

					SELECT no_cheque,
					       pagado,
					       wf_entregado,
					       wf_fecha,
					       wf_nombre,
					       wf_cedula,
						   en_firma
					  into _no_cheque,
					       _wf_pagado,
						   _wf_entregado,
						   _wf_fecha,
						   _wf_nombre,
						   _wf_cedula,
						   _en_firma
					  FROM chqchmae
					  where no_requis = _no_requis;

					if _pagado = 1 then	--inicio pagado rectrmae
					
						if _wf_pagado = 1 then
						
							 let _estatus = "Pagado";
							 if _cod_tipopago is not null or trim(_cod_tipopago) <> '' then
								 select nombre
								 into _descripago 
								 from rectipag where cod_tipopago = _cod_tipopago;
							 end if
							 
						else
						
						  let _estatus = "En Proceso";
						  
						end if
						
					else
					
							if _monto = '0.00' then
							
								let _estatus = "A Deducible";
								
							else
							
								let _estatus = "En Proceso";
								
							end if
							
					end if -- fin de pagado tabla rectrmae

	end if --fin del if de 013 declinado

    SELECT no_documento,
           cod_asegurado,
           cod_reclamante
           into _no_documento,
           _cod_asegurado,
           _cod_reclamante
    FROM recrcmae
    where no_reclamo = _no_reclamo;

		 select sum(monto_no_cubierto),
				sum(facturado),
				sum(elegible),
				sum(a_deducible),
				sum(co_pago),
				sum(coaseguro)
		   into	_gastos_no_cub,
				_gasto_fact,
				_gasto_eleg,
				_a_deducible,
				_co_pago,
				_coaseguro
		   from rectrcob
		  where no_tranrec = _no_tranrec;


    SELECT nombre, cedula
    into _nombre_paciente,_cedula
    FROM cliclien
    where cod_cliente = _cod_reclamante;

	
	select cod_entrada
	into  _cod_entrada
	from atcdocde
	where cod_asignacion = _cod_asignacion;
	
    select fecha
	into  _fecha_reclamo
	from atcdocma
	where cod_entrada = _cod_entrada;
	
if _cod_tipopago in('003','001') or _estatus = "Declinado" then -- ***** el cod_tipopago 001 solo se muestra para la base de datos de la cooperativa 07/02/2020 
   return _no_documento, --1
   _numrecla,            --2
   _no_factura,          --3
   _fecha_factura,       --4
   _nombre_paciente,     --5
   _transaccion,         --6
   _no_cheque,           --7
   _wf_fecha,            --8
   _wf_nombre,           --9
   _estatus,            --10
   _wf_entregado,       --11
   _wf_pagado,          --12
   _pagado,	            --13
   _wf_cedula,          --14
   _monto,              --15
   _gastos_no_cub,      --16
   _cod_entrada,        --17
   _tipotran,           --18
   _fecha_reclamo,		--19
   _no_unidad,		    --20
   _cedula,				--21
   _gasto_fact,			--22
   _gasto_eleg,			--23
   _a_deducible,		--24
   _co_pago,			--25
   _coaseguro,			--26
   _descripago          --27
   with resume;
end if
end foreach

end procedure