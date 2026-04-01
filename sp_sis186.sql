-- Procedimiento que Verifica si el campo de tiene impuesto coincide con el de la Póliza Original

-- creado    : 06/06/2013 - Autor: Román Gordón
-- sis v.2.0 - deivid, s.a.

drop procedure sp_sis186;
create procedure sp_sis186(a_no_documento char(20),a_tiene_impuesto smallint) 
returning	smallint;         

define _no_poliza		char(10);
define _tiene_imp_orig	smallint;

--set debug file to "sp_sis186.trc"; 
--trace on;                                                                

set isolation to dirty read;

let _tiene_imp_orig = null;

if a_no_documento in('0222-03284-01','0222-03285-01','0222-03286-01','0621-00162-01','1605-00016-01','0623-00163-01','0212-00135-01') and a_tiene_impuesto = 0 then
	return 0;
end if
if a_no_documento = '1505-00044-01' and a_tiene_impuesto = 0 then
	return 0;
end if
if a_no_documento = '0220-00346-01' and a_tiene_impuesto = 0 then
	return 0;
end if
if a_no_documento = '0602-00242-01' and a_tiene_impuesto = 0 then
	return 0;
end if
if a_no_documento = '0412-00066-01' and a_tiene_impuesto = 0 then
	return 0;
end if
if a_no_documento = '0210-01009-04' and a_tiene_impuesto = 1 then
	return 0;
end if
if a_no_documento in('0910-00002-01','0103-00448-01','0108-01107-01','0502-00053-01','0106-00533-01','0605-00159-01','0103-00297-01','0102-00343-01','0214-01274-09') then
	return 0;
end if
if a_no_documento = '0217-02235-01' and a_tiene_impuesto = 0 then
	return 0;
end if


 foreach
 
	 select tiene_impuesto
	  into _tiene_imp_orig
	  from emipomae
	 where no_documento = a_no_documento
	   and nueva_renov  = 'N'
	   exit foreach;
	   
 end foreach
 
if _tiene_imp_orig is null then
	let _no_poliza = sp_sis21(a_no_documento);
	select tiene_impuesto
	  into _tiene_imp_orig
	  from emipomae
	 where no_poliza = _no_poliza;
end if 
if _tiene_imp_orig <> a_tiene_impuesto then
	return 1;
end if
   
   
   
   
return 0;
end procedure;
