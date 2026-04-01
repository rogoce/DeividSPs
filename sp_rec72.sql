-- Transacciones Pendientes a los Proveedores de Reclamos

-- Creado    : 30/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/02/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec72;

create procedure sp_rec72(
a_compania char(3), 
a_periodo char(7)
) 
returning char(20),
          char(10),
		  date,
		  char(7),
		  dec(16,2),
		  dec(16,2),
		  char(10),
		  char(100),
		  char(50);

define _cod_cliente		char(10);
define _transaccion		char(10);
define _fecha			date;
define _numrecla		char(20);
define _periodo			char(7);
define _monto			dec(16,2);
define _variacion		dec(16,2);
define _nombre_cliente	char(100);
define _nombre_compania	char(50);
define _no_tranrec		char(10);

set isolation to dirty read;

let _nombre_compania = sp_sis01(a_compania); 

create temp table tmp_prove(
cod_cliente		char(10),
numrecla		char(20),
monto			dec(16,2)
) with no log;


foreach
select cod_cliente,
	   numrecla,
	   monto
  into _cod_cliente,
	   _numrecla,
	   _monto
  from rectrmae
 where periodo      <= a_periodo
   and pagado       = 0
   and actualizado  = 1
   and monto        <> 0.00
   and cod_tipotran = "004"	

	insert into tmp_prove
	values (_cod_cliente, _numrecla, _monto);

end foreach

foreach
select cod_cliente,
       numrecla,
	   sum(monto)
  into _cod_cliente,
       _numrecla,
	   _monto
  from tmp_prove
 group by 1, 2
having sum(monto) <> 0.00

   foreach
	select transaccion,
		   fecha,
		   periodo,
		   monto,
		   variacion,
		   no_tranrec
	  into _transaccion,
		   _fecha,
		   _periodo,
		   _monto,
		   _variacion,
		   _no_tranrec
	  from rectrmae
	 where periodo      <= a_periodo
	   and pagado       = 0
	   and actualizado  = 1
	   and monto        <> 0.00
	   and cod_tipotran = "004"	
	   and cod_cliente  = _cod_cliente
	   and numrecla     = _numrecla

		select nombre
		  into _nombre_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;

		return _numrecla,
		       _transaccion,
			   _fecha,
			   _periodo,
			   _monto,
			   _variacion,
			   _cod_cliente,
			   _nombre_cliente,
			   _nombre_compania
			   with resume;

	end foreach

end foreach

drop table tmp_prove;

end procedure
