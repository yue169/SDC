/**
 * Copyright 2010 Bernard Helyer
 * This file is part of SDC. SDC is licensed under the GPL.
 * See LICENCE or sdc.d for more details.
 */
module sdc.gen.type;

import std.string;

import llvm.c.Core;

import sdc.util;
import sdc.compilererror;
import sdc.location;
import sdc.extract.base;
import ast = sdc.ast.all;
import sdc.gen.sdcmodule;
import sdc.gen.value;


enum DType
{
    None,
    Void,
    Bool,
    Char,
    Ubyte,
    Byte,
    Wchar,
    Ushort,
    Short,
    Dchar,
    Uint,
    Int,
    Ulong,
    Long,
    Float,
    Double,
    Real,
    Pointer,
    NullPointer,
    Array,
    Complex,
    Function,
    Struct,
    Inferred,
}

Type dtypeToType(DType dtype, Module mod)
{
    final switch (dtype) with (DType) {
    case None:
        break;
    case Void:
        return new VoidType(mod);
    case Bool:
        return new BoolType(mod);
    case Char:
    case Ubyte:
    case Byte:
    case Wchar:
    case Ushort:
    case Short:
    case Dchar:
    case Uint:
        break;
    case Int:
        return new IntType(mod);
    case Ulong:
        break;
    case Long:
        return new LongType(mod); 
    case Float:
        break;
    case Double:
        return new DoubleType(mod);
    case Real:
    case Pointer:
    case NullPointer:
    case Array:
    case Complex:
    case Function:
    case Struct:
        break;
    case Inferred:
        return new InferredType(mod);
    }
    throw new CompilerPanic("tried to get Type out of invalid DType.");
}

pure bool isComplexDType(DType dtype)
{
    return dtype >= DType.Complex;
}

pure bool isIntegerDType(DType dtype)
{
    return dtype >= DType.Bool && dtype <= DType.Long;
}

pure bool isFPDtype(DType dtype)
{
    return dtype >= DType.Float && dtype <= DType.Double;
}

abstract class Type
{
    DType dtype;
    ast.Access access;
    
    this(Module mod)
    {
        mModule = mod;
        access = mod.currentAccess;
    }
    
    LLVMTypeRef llvmType()
    {
        return mType;
    }
    
    /// An opEquals appropriate for simple types.
    override bool opEquals(Object o)
    {
        auto asType = cast(Type) o;
        if (!asType) return false;
        
        return this.mType == asType.mType;
    }
    
    Value getValue(Module mod, Location location);
    
    Type importToModule(Module mod)
    {
        return this;
    }
    
    protected Module mModule;
    protected LLVMTypeRef mType;
}

class VoidType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Void;
        mType = LLVMVoidTypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new VoidValue(mod, location);
    }
}

class BoolType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Bool;
        mType = LLVMInt1TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    { 
        return new BoolValue(mod, location);
    }
}

class ByteType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Byte;
        mType = LLVMInt8TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new ByteValue(mod, location);
    }
}

class UbyteType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Ubyte;
        mType = LLVMInt8TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new UbyteValue(mod, location);
    }
}

class ShortType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Short;
        mType = LLVMInt16TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new ShortValue(mod, location);
    }
}

class UshortType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Ushort;
        mType = LLVMInt16TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new UshortValue(mod, location);
    }
}

class IntType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Int;
        mType = LLVMInt32TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new IntValue(mod, location);
    }
}

class UintType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Uint;
        mType = LLVMInt32TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new UintValue(mod, location);
    }
}

class LongType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Long;
        mType = LLVMInt64TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new LongValue(mod, location);
    }
}

class UlongType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Ulong;
        mType = LLVMInt64TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new UlongValue(mod, location);
    }
}

class FloatType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Float;
        mType = LLVMFloatTypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new FloatValue(mod, location);
    }
}

class DoubleType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Double;
        mType = LLVMDoubleTypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new DoubleValue(mod, location);
    }
}

class RealType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Real;
        mType = LLVMFP128TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new RealValue(mod, location);
    }
}

class CharType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Char;
        mType = LLVMInt8TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new CharValue(mod, location);
    }
}

class WcharType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Wchar;
        mType = LLVMInt16TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new WcharValue(mod, location);
    }
}

class DcharType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Dchar;
        mType = LLVMInt32TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new DcharValue(mod, location);
    }
}

class PointerType : Type
{
    Type base;
    
    this(Module mod, Type base)
    {
        super(mod);
        this.base = base;
        dtype = DType.Pointer;
        if (base.dtype == DType.Void) {
            mType = LLVMPointerType(LLVMInt8TypeInContext(mod.context), 0);
        } else {
            mType = LLVMPointerType(base.llvmType, 0);
        }
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new PointerValue(mod, location, base);
    }
}

class NullPointerType : PointerType
{
    this(Module mod)
    {
        super(mod, new VoidType(mod));
        dtype = DType.NullPointer;
    }
}

class ArrayType : Type
{
    Type base;
    StructType structType;
    PointerType structTypePointer;
    
    this(Module mod, Type base)
    {
        super(mod);
        this.base = base;
        dtype = DType.Array;
        structType = new StructType(mod);
        structType.addMemberVar("length", new IntType(mod));
        structType.addMemberVar("ptr", new PointerType(mod, base));
        structType.declare();
        structTypePointer = new PointerType(mod, structType);
        mType = structTypePointer.llvmType;
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new ArrayValue(mod, location, base);
    }
}

class FunctionType : Type
{
    Type returnType;
    Type[] argumentTypes;
    string[] argumentNames;
    ast.Linkage linkage;
    StructType parentAggregate;
    
    this(Module mod, ast.FunctionDeclaration functionDeclaration)
    {
        super(mod);
        linkage = mod.currentLinkage;
        dtype = DType.Function;
        returnType = astTypeToBackendType(functionDeclaration.retval, mModule, OnFailure.DieWithError);
        foreach (param; functionDeclaration.parameters) {
            argumentTypes ~= astTypeToBackendType(param.type, mModule, OnFailure.DieWithError);
            argumentNames ~= param.identifier !is null ? extractIdentifier(param.identifier) : "";
        }
    }
    
    this(Module mod, Type retval, Type[] args, string[] argNames)
    {
        super(mod);
        dtype = DType.Function;
        returnType = retval;
        argumentTypes = args;
        argumentNames = argNames;
    }
    
    void declare()
    {
        LLVMTypeRef[] params;
        foreach (t; argumentTypes) {
            params ~= t.llvmType;
        }
        mType = LLVMFunctionType(returnType.llvmType, params.ptr, params.length, false);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return null;
    }
}

class StructType : Type
{
    ast.QualifiedName name;
    
    this(Module mod)
    {
        super(mod);
        dtype = DType.Struct;
    }
    
    void declare()
    {
        LLVMTypeRef[] types;
        foreach (member; members) {
            types ~= member.llvmType;
        }
        mType = LLVMStructTypeInContext(mModule.context, types.ptr, types.length, false);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new StructValue(mod, location, this);
    }

    void addMemberVar(string id, Type t)
    {
        memberPositions[id] = members.length;
        members ~= t;
    }
    
    void addMemberFunction(string id, Value f)
    {
        memberFunctions[id] = f;
        mModule.globalScope.add(id, new Store(f));
    }
    
    override Type importToModule(Module mod)
    {
        auto t = new StructType(mod);
        foreach (name, index; memberPositions) {
            t.addMemberVar(name, members[index].importToModule(mod));
        }
        foreach (name, func; memberFunctions) {
            t.addMemberFunction(name, func.importToModule(mod));
        }
        t.declare();
        return t;
    }
    
    Type[] members;
    int[string] memberPositions;
    Value[string] memberFunctions;
}

/* InferredType means, as soon as we get enough information
 * to know what type this is, replace InferredType with the
 * real one.
 */
class InferredType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Inferred;
    }
    
    override Value getValue(Module mod, Location location)
    {
        throw new CompilerPanic(location, "attempted to call InferredType.getValue");
    }
}
