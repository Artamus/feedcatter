// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.6
// 	protoc        v3.12.4
// source: feedcatter/food.proto

package feedcatter

import (
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"

	timestamp "github.com/golang/protobuf/ptypes/timestamp"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type Food_FoodState int32

const (
	Food_STATE_UNSPECIFIED   Food_FoodState = 0
	Food_AVAILABLE           Food_FoodState = 1
	Food_PARTIALLY_AVAILABLE Food_FoodState = 2
	Food_EATEN               Food_FoodState = 3
)

// Enum value maps for Food_FoodState.
var (
	Food_FoodState_name = map[int32]string{
		0: "STATE_UNSPECIFIED",
		1: "AVAILABLE",
		2: "PARTIALLY_AVAILABLE",
		3: "EATEN",
	}
	Food_FoodState_value = map[string]int32{
		"STATE_UNSPECIFIED":   0,
		"AVAILABLE":           1,
		"PARTIALLY_AVAILABLE": 2,
		"EATEN":               3,
	}
)

func (x Food_FoodState) Enum() *Food_FoodState {
	p := new(Food_FoodState)
	*p = x
	return p
}

func (x Food_FoodState) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (Food_FoodState) Descriptor() protoreflect.EnumDescriptor {
	return file_feedcatter_food_proto_enumTypes[0].Descriptor()
}

func (Food_FoodState) Type() protoreflect.EnumType {
	return &file_feedcatter_food_proto_enumTypes[0]
}

func (x Food_FoodState) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use Food_FoodState.Descriptor instead.
func (Food_FoodState) EnumDescriptor() ([]byte, []int) {
	return file_feedcatter_food_proto_rawDescGZIP(), []int{0, 0}
}

type Food struct {
	state               protoimpl.MessageState `protogen:"open.v1"`
	Id                  int32                  `protobuf:"varint,1,opt,name=id,proto3" json:"id,omitempty"`
	CreatedAt           *timestamp.Timestamp   `protobuf:"bytes,2,opt,name=created_at,json=createdAt,proto3" json:"created_at,omitempty"`
	Name                string                 `protobuf:"bytes,3,opt,name=name,proto3" json:"name,omitempty"`
	State               Food_FoodState         `protobuf:"varint,4,opt,name=state,proto3,enum=feedcatter.Food_FoodState" json:"state,omitempty"`
	AvailablePercentage float64                `protobuf:"fixed64,5,opt,name=available_percentage,json=availablePercentage,proto3" json:"available_percentage,omitempty"`
	unknownFields       protoimpl.UnknownFields
	sizeCache           protoimpl.SizeCache
}

func (x *Food) Reset() {
	*x = Food{}
	mi := &file_feedcatter_food_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Food) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Food) ProtoMessage() {}

func (x *Food) ProtoReflect() protoreflect.Message {
	mi := &file_feedcatter_food_proto_msgTypes[0]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Food.ProtoReflect.Descriptor instead.
func (*Food) Descriptor() ([]byte, []int) {
	return file_feedcatter_food_proto_rawDescGZIP(), []int{0}
}

func (x *Food) GetId() int32 {
	if x != nil {
		return x.Id
	}
	return 0
}

func (x *Food) GetCreatedAt() *timestamp.Timestamp {
	if x != nil {
		return x.CreatedAt
	}
	return nil
}

func (x *Food) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

func (x *Food) GetState() Food_FoodState {
	if x != nil {
		return x.State
	}
	return Food_STATE_UNSPECIFIED
}

func (x *Food) GetAvailablePercentage() float64 {
	if x != nil {
		return x.AvailablePercentage
	}
	return 0
}

var File_feedcatter_food_proto protoreflect.FileDescriptor

const file_feedcatter_food_proto_rawDesc = "" +
	"\n" +
	"\x15feedcatter/food.proto\x12\n" +
	"feedcatter\x1a\x1fgoogle/protobuf/timestamp.proto\"\xa1\x02\n" +
	"\x04Food\x12\x0e\n" +
	"\x02id\x18\x01 \x01(\x05R\x02id\x129\n" +
	"\n" +
	"created_at\x18\x02 \x01(\v2\x1a.google.protobuf.TimestampR\tcreatedAt\x12\x12\n" +
	"\x04name\x18\x03 \x01(\tR\x04name\x120\n" +
	"\x05state\x18\x04 \x01(\x0e2\x1a.feedcatter.Food.FoodStateR\x05state\x121\n" +
	"\x14available_percentage\x18\x05 \x01(\x01R\x13availablePercentage\"U\n" +
	"\tFoodState\x12\x15\n" +
	"\x11STATE_UNSPECIFIED\x10\x00\x12\r\n" +
	"\tAVAILABLE\x10\x01\x12\x17\n" +
	"\x13PARTIALLY_AVAILABLE\x10\x02\x12\t\n" +
	"\x05EATEN\x10\x03BCZAgithub.com/Artamus/feedcatter/feedcatter-go/feedcatter;feedcatterb\x06proto3"

var (
	file_feedcatter_food_proto_rawDescOnce sync.Once
	file_feedcatter_food_proto_rawDescData []byte
)

func file_feedcatter_food_proto_rawDescGZIP() []byte {
	file_feedcatter_food_proto_rawDescOnce.Do(func() {
		file_feedcatter_food_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_feedcatter_food_proto_rawDesc), len(file_feedcatter_food_proto_rawDesc)))
	})
	return file_feedcatter_food_proto_rawDescData
}

var file_feedcatter_food_proto_enumTypes = make([]protoimpl.EnumInfo, 1)
var file_feedcatter_food_proto_msgTypes = make([]protoimpl.MessageInfo, 1)
var file_feedcatter_food_proto_goTypes = []any{
	(Food_FoodState)(0),         // 0: feedcatter.Food.FoodState
	(*Food)(nil),                // 1: feedcatter.Food
	(*timestamp.Timestamp)(nil), // 2: google.protobuf.Timestamp
}
var file_feedcatter_food_proto_depIdxs = []int32{
	2, // 0: feedcatter.Food.created_at:type_name -> google.protobuf.Timestamp
	0, // 1: feedcatter.Food.state:type_name -> feedcatter.Food.FoodState
	2, // [2:2] is the sub-list for method output_type
	2, // [2:2] is the sub-list for method input_type
	2, // [2:2] is the sub-list for extension type_name
	2, // [2:2] is the sub-list for extension extendee
	0, // [0:2] is the sub-list for field type_name
}

func init() { file_feedcatter_food_proto_init() }
func file_feedcatter_food_proto_init() {
	if File_feedcatter_food_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_feedcatter_food_proto_rawDesc), len(file_feedcatter_food_proto_rawDesc)),
			NumEnums:      1,
			NumMessages:   1,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_feedcatter_food_proto_goTypes,
		DependencyIndexes: file_feedcatter_food_proto_depIdxs,
		EnumInfos:         file_feedcatter_food_proto_enumTypes,
		MessageInfos:      file_feedcatter_food_proto_msgTypes,
	}.Build()
	File_feedcatter_food_proto = out.File
	file_feedcatter_food_proto_goTypes = nil
	file_feedcatter_food_proto_depIdxs = nil
}
