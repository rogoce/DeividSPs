-- Obtener el estado de los cheques de los hospitales

-- Creado    : 21/12/2010 - Autor: Federico Coronado

-- SIS - Pagina Web.

drop procedure sp_web06;

create procedure "informix".sp_web06(a_id_proveedor char(10),a_no_factura varchar(10))
returning char(20),
char(20),
varchar(10),
char(10),
char(40),
char(10),
char(10),
char(10),
char(30),
varchar(20),
integer,
integer,
integer,
char(10),
decimal(10,2),
decimal(10,2),
char(3);

define _no_reclamo char(10);
define _no_factura varchar(10);
define _fecha_factura char(10);
define _no_documento char(20);
define _cod_asegurado char(10);
define _nombre_paciente char(40);
define _transaccion char(10);
define _pagado char(10);
define _no_requis char(20);
define _numrecla char(20);
define _fecha	date;
define _periodo	char(7);
define _tipotran char(3);
define _no_cheque char(10);
define _wf_fecha char(10);
define _wf_nombre char(30);
define _wf_cedula char(10);
define _cod_reclamante char(10);

define _wf_pagado integer;
define _wf_entregado integer;
define _en_firma smallint;

define _estatus	varchar(20);
define _no_tranrec varchar(10);

define _monto decimal(10,2);
define _gastos_no_cub decimal(10,2);


let _fecha   = today;
let _fecha   = _fecha - 3 units month;
let _periodo = sp_sis39(_fecha);


set isolation to dirty read;

-- busqueda por id del proveedor

if a_no_factura = ' ' then

foreach

	 SELECT no_reclamo,
	        numrecla,
	        no_factura,
	        fecha_factura,
	        transaccion,
	        pagado,
	        no_requis,
	        cod_tipotran,
		    monto,
            no_tranrec
	   into _no_reclamo,
	        _numrecla,
	        _no_factura,
	        _fecha_factura,
	        _transaccion,
	        _pagado,
	        _no_requis,
		    _tipotran,
		    _monto,
		    _no_tranrec
	   FROM rectrmae
	  where cod_compania = "001"
            and actualizado  = 1
			and periodo      >= _periodo
			and cod_tipotran in ('013', '004')
			and cod_tipopago = '001'
			and cod_cliente  = a_id_proveedor
			and anular_nt    is null
			order by fecha_factura DESC

	let _no_cheque 		= '';
	let _wf_pagado 		= '';
	let _wf_entregado	= '';
	let _wf_fecha 		= '';
	let _wf_nombre 		= '';
	let _wf_cedula 		= '';

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


						   	--if _wf_entregado = 1 then


						   		--let _estatus = "Pagado y Retirado";

						  	--else

							 	--let _estatus = "Pagado por Retirar";

						   	--end if

						else

						  -- let _estatus = "En Firma";

						  let _estatus = "En Proceso";

						end if

					else

						--if _en_firma = 0 then

							let _estatus = "En Proceso";

						--else

							--let _estatus = "En Firma";

						--end if

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

		 select	monto_no_cubierto
		   into	_gastos_no_cub
		   from rectrcob
		  where no_tranrec = _no_tranrec;


    SELECT nombre
    into _nombre_paciente
    FROM cliclien
    where cod_cliente = _cod_reclamante;


   return _no_documento,
   _numrecla,
   _no_factura,
   _fecha_factura,
   _nombre_paciente,
   _transaccion,
   _no_cheque,
   _wf_fecha,
   _wf_nombre,
   _estatus,
   _wf_entregado,
   _wf_pagado,
   _pagado,	 --
   _wf_cedula,
   _monto,
   _gastos_no_cub,
   _tipotran with resume;

end foreach

-- Busqueda por # de factura y id de proveedor

else

foreach

	 SELECT no_reclamo,
	        numrecla,
	        no_factura,
	        fecha_factura,
	        transaccion,
	        pagado,
	        no_requis,
	        cod_tipotran,
		    monto,
            no_tranrec
	   into _no_reclamo,
	        _numrecla,
	        _no_factura,
	        _fecha_factura,
	        _transaccion,
	        _pagado,
	        _no_requis,
		    _tipotran,
		    _monto,
            _no_tranrec
	   FROM rectrmae
	  where cod_compania = "001"
		and actualizado  = 1
	    and cod_tipotran in ('013', '004')
		and cod_tipopago = '001'
	    and periodo >= _periodo
	    and cod_cliente  = a_id_proveedor
	    and anular_nt is null
        and no_factura = a_no_factura
 	    order by fecha_factura DESC

	let _no_cheque 		= '';
	let _wf_pagado 		= '';
	let _wf_entregado	= '';
	let _wf_fecha 		= '';
	let _wf_nombre 		= '';
	let _wf_cedula 		= '';

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


						   	--if _wf_entregado = 1 then

						   		--let _estatus = "Pagado y Retirado";

						  	--else

							 	--let _estatus = "Pagado por Retirar";

						   	--end if

						else

						   --let _estatus = "En Firma";
						  let _estatus = "En Proceso";

						end if

					else

						--if _en_firma = 0 then

							let _estatus = "En Proceso";

						--else

							--let _estatus = "En Firma";

						--end if

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


	--monto no cubierto
	select	monto_no_cubierto
	into	_gastos_no_cub
	from rectrcob
	where no_tranrec = _no_tranrec;


    SELECT nombre
    into _nombre_paciente
    FROM cliclien
    where cod_cliente = _cod_reclamante;


   return _no_documento,
   _numrecla,
   _no_factura,
   _fecha_factura,
   _nombre_paciente,
   _transaccion,
   _no_cheque,
   _wf_fecha,
   _wf_nombre,
   _estatus,
   _wf_entregado,
   _wf_pagado,
   _pagado,	 --
   _wf_cedula,
   _monto,
   _gastos_no_cub,
   _tipotran with resume;

end foreach
end if
end procedure